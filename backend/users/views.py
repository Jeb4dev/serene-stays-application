import datetime
import jwt
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import AuthenticationFailed, ValidationError
from rest_framework.response import Response

from conf.settings import JWT_SECRET
from .models import User
from .serializers import UserSerializer


def get_token(request):
    auth_header = request.headers.get("Authorization")
    if auth_header:
        auth_parts = auth_header.split(" ")
        if len(auth_parts) > 1:
            return auth_parts[1]
    return None

@api_view(["POST"])
def register(request):
    """
    API endpoint that creates a new user and returns the created user in JSON format.

    :param request: POST request with name, email and age in JSON format
    :return: JSON response with newly created user or error message
    """

    # Try to create a new user
    try:
        serializer = UserSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        # Create a new OAuth token for the user -- NOT IMPLEMENTED
        # app = Application.objects.first()  # Get the first registered application
        # token = AccessToken.objects.create(
        #     user=user,
        #     application=app,
        #     expires=timezone.now() + timedelta(days=1),
        #     scope="read write"
        # )
        #
        # return Response({
        #     "result": "success",
        #     "data": serializer.data,
        #     "access_token": token.token
        # }, status=status.HTTP_201_CREATED)

        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)

    # Catch validation errors and return a 400 response
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)

    # Catch unexpected errors and return a 500 response
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def login(request):
    """
    API endpoint that logs in an existing user and returns jwt token in JSON format.

    :param request: POST request with email and password in JSON format
    :return: JSON response with jwt token or error message
    """
    try:
        email = request.data["email"]
        password = request.data["password"]

        user = User.objects.filter(email=email).first()

        if user is None:
            raise AuthenticationFailed("User not found!")

        if not user.check_password(password):
            raise AuthenticationFailed("Incorrect password!")

        payload = {
            "id": user.id,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=60),
            "iat": datetime.datetime.utcnow(),
        }

        token = jwt.encode(payload, JWT_SECRET, algorithm="HS256")

        response = Response()

        response.set_cookie(key="jwt", value=token, httponly=True)
        response.data = {"result": "success", "jwt": token}
        response.status = status.HTTP_200_OK

        return response

    except AuthenticationFailed as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_401_UNAUTHORIZED)

    except KeyError as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def logout(request):
    """
    API endpoint that logs out an existing user

    :param request: POST request
    :return: JSON response with success message or error message
    """

    # try to delete the jwt cookie
    try:
        response = Response()
        response.delete_cookie("jwt")
        token = get_token(request)
        response.headers["Authorization"] = ""
        response.data = {"result": "success", "message": "Successfully logged out!"}
        response.status = status.HTTP_200_OK
        return response

    # Catch unexpected errors and return a 500 response
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_data(request):
    """
    API endpoint that returns a list of all users in JSON format.

    :param request: GET request
    :return: JSON response with list of all users or error message
    """

    # Try to get all users
    try:
        token = get_token(request)

        if not token:
            raise AuthenticationFailed("Unauthenticated!")

        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed("Unauthenticated!")

        user = User.objects.filter(id=payload["id"]).first()
        serializer = UserSerializer(user)

        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    # Catch authentication errors and return a 401 response
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_401_UNAUTHORIZED)

    # Catch unexpected errors and return a 500 response
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["PUT"])
def update_data(request):
    """
    API endpoint that updates a user and returns the updated user in JSON format.

    :param request: PUT request with fields to update in JSON format
    :return: JSON response with updated user or error message
    """

    # Try to get all users
    try:
        token = get_token(request)

        if not token:
            raise AuthenticationFailed("Unauthenticated!")

        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed("Unauthenticated!")

        user = User.objects.filter(id=payload["id"]).first()

        serializer = UserSerializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    # Catch authentication errors and return a 401 response
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_401_UNAUTHORIZED)

    # Catch unexpected errors and return a 500 response
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

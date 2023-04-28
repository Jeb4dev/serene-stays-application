from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.exceptions import AuthenticationFailed, ValidationError
from .serializers import ServiceSerializer



@api_view(["POST"])
def create_service(request):
    """
    API endpoint that creates a new service and returns the created service in JSON format.

    :param request: POST request with area, name, description, service_price and vat_price in JSON format
    :return: JSON response with newly created service with correct fields or error message
    """
    # create a new service
    try:
        serializer = ServiceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
    
    # Throw exception if validation errors occur
    except ValidationError as e:
        return Response({"resul": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    # If unexpected error occurs, return a 500 response
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_service(request):
    """
    Gets a service.
    """
    return Response({}, status=status.HTTP_404_NOT_FOUND)


@api_view(["PUT"])
def update_service(request):
    """
    Updates a service.
    """
    return Response({}, status=status.HTTP_404_NOT_FOUND)


@api_view(["DELETE"])
def delete_service(request):
    """
    Deletes a service.
    """
    return Response({}, status=status.HTTP_404_NOT_FOUND)

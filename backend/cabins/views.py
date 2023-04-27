from django.http import Http404
from django.shortcuts import render
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import ValidationError
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response

from cabins.models import Cabin
from cabins.serializers import CabinSerializer, PostCodeSerializer, AreaCodeSerializer



@api_view(["POST"])
def create_cabin(request):
    """
    Creates a new cabin.
    """
    try:
        serializer = CabinSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_cabins(request):
    """
    Returns a list of cabins filtered by area, post code and id.
    :param request: GET request with optional area, post code and id
    :return: JSON response with list of cabins or error message
    """
    try:
        area = request.GET.get("area")
        post_code = request.GET.get("zip_code")
        cabin_id = request.GET.get("id")
        beds = request.GET.get("num_of_beds")

        # Get all cabins
        cabins = Cabin.objects.all()

        # Filter by cabin id
        if cabin_id:
            cabin = get_object_or_404(Cabin, pk=cabin_id)
            serializer = CabinSerializer(cabin)
            return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

        # Filter by other parameters
        if area:
            cabins = cabins.filter(area=area)
        if post_code:
            cabins = cabins.filter(zip_code=post_code)
        if beds:
            # loop through all cabins and check if the number of beds is greater than or equal to the number of beds
            cabins = [cabin for cabin in cabins if cabin.num_of_beds >= int(beds)]

        # If no cabin is found, return a 404 response
        if not cabins:
            raise Http404

        # Serialize and return the data
        serializer = CabinSerializer(cabins, many=True)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    except Http404:
        return Response({"result": "error", "message": "No cabins found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def create_area(request):
    """
    Creates a new area.
    """
    try:
        serializer = AreaCodeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



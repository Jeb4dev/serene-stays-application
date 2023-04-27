from django.shortcuts import render
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from cabins.serializers import CabinSerializer, PostCodeSerializer, AreaCodeSerializer


# Create your views here.


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



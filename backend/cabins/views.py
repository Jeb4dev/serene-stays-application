from django.http import Http404
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import ValidationError
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response

from cabins.models import Cabin, Area
from cabins.serializers import CabinSerializer, AreaSerializer


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


@api_view(["PATCH"])
def update_cabin(request):
    """
    Updates a cabin.
    :param request: PUT request with updated cabin data
    :return: JSON response with updated cabin data or error message
    """
    try:
        cabin_id = request.query_params.get("id")
        cabin = get_object_or_404(Cabin, pk=cabin_id)
        serializer = CabinSerializer(cabin, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No cabin found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["DELETE"])
def delete_cabin(request):
    """
    Deletes a cabin.
    :param request: DELETE request with cabin id
    :return: JSON response with success message or error message
    """
    try:
        cabin_id = request.query_params.get("id")
        cabin = get_object_or_404(Cabin, pk=cabin_id)
        cabin.delete()
        return Response({"result": "success", "message": "Cabin deleted successfully"}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No cabin found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["POST"])
def create_area(request):
    """
    Creates a new area.
    """
    try:
        serializer = AreaSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_areas(request):
    """
    Returns a list of areas optionally filtered by area name
    :param request: GET request with optional area name
    :return: JSON response with list of areas or error message
    """
    try:
        area_name = request.query_params.get("area")

        # Get all areas
        areas = Area.objects.all()

        # Filter by area id
        if area_name:
            area = get_object_or_404(Area, pk=area_name)
            serializer = AreaSerializer(area)
            return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

        # If no area is found, return a 404 response
        if not areas:
            raise Http404

        # Serialize and return the data
        serializer = AreaSerializer(areas, many=True)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    except Http404:
        return Response({"result": "error", "message": "No areas found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["PATCH"])
def update_area(request):
    """
    Updates an area.
    :param request: PUT request with updated area data
    :return: JSON response with updated area data or error message
    """
    try:
        area_name = request.query_params.get("area")
        area = get_object_or_404(Area, pk=area_name)
        serializer = AreaSerializer(area, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No area found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["DELETE"])
def delete_area(request):
    """
    Deletes an area.
    :param request: DELETE request with area id
    :return: JSON response with success message or error message
    """
    try:
        area_name = request.query_params.get("area")
        area = get_object_or_404(Area, pk=area_name)
        area.delete()
        return Response({"result": "success", "message": "Area deleted successfully"}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No area found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

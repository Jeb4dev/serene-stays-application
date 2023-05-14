from django.http import Http404
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import ValidationError
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response

from services.models import Service
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
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    # If unexpected error occurs, return a 500 response
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_service(request):
    """
    Gets a service.
    """
    try:
        area = request.GET.get("area")
        name = request.GET.get("name")
        request.GET.get("description")  # how to tie to service name?
        service_price = request.GET.get("service_price")
        vat_price = request.GET.get("vat_price")

        # Do we need to fetch all services ?
        services = Service.objects.all()

        # Should description be tied to the service name?
        # how do we filter the services? by description first? or the set primary_key that is area?
        if area:
            services = services.filter(area=area)
        if name:
            services = services.filter(name=name)
        if service_price:
            services = services.filter(service_price=vat_price)

        if not services:
            raise Http404

        # Serialize and return data
        serializer = ServiceSerializer(services, many=True)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    except Http404:
        return Response({"result": "error", "message": "No services found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["PUT"])
def update_service(request):
    """
    Updates a service.
    """
    try:
        area = request.query_params.get("area")
        service = get_object_or_404(Service, pk=area)
        serializer = ServiceSerializer(service, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No service found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["DELETE"])
def delete_service(request):
    """
    Deletes a service.
    """
    try:
        area = request.query_params.get("area")
        service = get_object_or_404(Service, pk=area)
        service.delete()
        return Response({"result": "success", "message": "Service deleted successfully"}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No service found"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

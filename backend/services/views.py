from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(["POST"])
def create_service(request):
    """
    Creates a new service.
    """
    return Response({}, status=status.HTTP_404_NOT_FOUND)


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

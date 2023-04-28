from django.http import Http404
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import ValidationError
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response

from reservations.models import Reservation
from reservations.serializer import ReservationSerializer

"""
RESERVATIONS API ENDPOINTS
"""


@api_view(["POST"])
def create_reservation(request):
    """
    Creates a new reservation.
    """
    try:
        serializer = ReservationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_reservations(request):
    """
    Returns all reservations.
    """
    try:
        reservation_id = request.GET.get("id")
        reservations = Reservation.objects.all()
        if reservation_id:
            reservations = get_object_or_404(Reservation, pk=reservation_id)
        serializer = ReservationSerializer(reservations, many=True)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No reservations found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["PUT"])
def update_reservation(request):
    """
    Updates a reservation.
    """
    try:
        reservation_id = request.data.get("id")
        reservation = get_object_or_404(Reservation, pk=reservation_id)
        serializer = ReservationSerializer(reservation, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No reservations found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["DELETE"])
def delete_reservation(request):
    """
    Deletes a reservation.
    """
    try:
        reservation_id = request.data.get("id")
        reservation = get_object_or_404(Reservation, pk=reservation_id)
        reservation.delete()
        return Response({"result": "success", "message": "Reservation deleted"}, status=status.HTTP_200_OK)
    except Http404:
        return Response({"result": "error", "message": "No reservations found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


"""
INVOICES API ENDPOINTS
"""


@api_view(["POST"])
def create_invoice(request):
    """
    Creates a new invoice.
    """
    pass


@api_view(["GET"])
def get_invoices(request):
    """
    Returns all invoices.
    """
    pass


@api_view(["PUT"])
def update_invoice(request):
    """
    Updates an invoice.
    """
    pass


@api_view(["DELETE"])
def delete_invoice(request):
    """
    Deletes an invoice.
    """
    pass

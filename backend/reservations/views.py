import jwt
from django.http import Http404
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.exceptions import ValidationError, AuthenticationFailed
from rest_framework.generics import get_object_or_404
from rest_framework.response import Response

from conf.settings import JWT_SECRET
from reservations.models import Reservation, Invoice
from reservations.serializer import ReservationSerializer, InvoiceSerializer
from users.models import User

"""
RESERVATIONS API ENDPOINTS
"""

def get_token(request):
    auth_header = request.headers.get("Authorization")
    if auth_header:
        auth_parts = auth_header.split(" ")
        if len(auth_parts) > 1:
            return auth_parts[1]
    return None


def auth(token):
    if not token:
        raise AuthenticationFailed("Unauthenticated: no token provided!")

    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
    except jwt.DecodeError:
        raise AuthenticationFailed("Unauthenticated: token invalid!")
    except jwt.ExpiredSignatureError:
        raise AuthenticationFailed("Unauthenticated: token expired!")

    return User.objects.filter(id=payload["id"]).first()


@api_view(["POST"])
def create_reservation(request):
    """
    Creates a new reservation.
    """
    try:
        token = get_token(request)
        user = auth(token)
        serializer = ReservationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.create(serializer.validated_data)
        serializer.save(customer=user)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
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
        token = get_token(request)
        user = auth(token)
        reservation_id = request.GET.get("reservation")
        reservations = Reservation.objects.all()
        if not user.is_staff:
            reservations = reservations.filter(customer=user)
        if reservation_id:
            reservations = reservations.filter(pk=reservation_id)
        if not reservations:
            raise Http404
        serializer = ReservationSerializer(reservations, many=True)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
    except Http404:
        return Response({"result": "error", "message": "No reservations found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["PATCH"])
def update_reservation(request):
    """
    Updates a reservation.
    """
    try:
        token = get_token(request)
        user = auth(token)

        reservation_id = request.GET.get("reservation")
        reservation = get_object_or_404(Reservation, pk=reservation_id)

        if reservation.customer.id != user.id:
            if not user.is_staff:
                raise AuthenticationFailed(f"Unauthenticated!")

        serializer = ReservationSerializer(reservation, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
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
        token = get_token(request)
        user = auth(token)
        reservation_id = request.GET.get("reservation")
        if not reservation_id:
            raise ValidationError("Reservation ID is required")
        reservation = get_object_or_404(Reservation, pk=reservation_id)

        if reservation.customer.id != user.id:
            if not user.is_staff:
                raise AuthenticationFailed(f"Unauthenticated!")

        reservation.delete()
        return Response({"result": "success", "message": "Reservation deleted"}, status=status.HTTP_200_OK)
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
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
    try:
        token = get_token(request)
        user = auth(token)

        # Only staff can manually create invoices
        if not user.is_staff:
            raise AuthenticationFailed(f"Unauthenticated!")

        serializer = InvoiceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.create(serializer.validated_data)
        serializer.save()
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_201_CREATED)

    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
    except Http404:
        return Response({"result": "error", "message": "No invoices found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["GET"])
def get_invoices(request):
    """
    Returns all invoices or a specific invoice. Only staff can view all invoices. Users can view their own invoices.
    """
    try:
        token = get_token(request)
        user = auth(token)

        reservation_id = request.GET.get("invoice")
        invoices = Invoice.objects.all()
        if not user.is_staff:
            invoices = invoices.filter(reservation_id__customer=user)
        if reservation_id:
            invoices = invoices.filter(pk=reservation_id)
        if not invoices:
            raise Http404
        serializer = InvoiceSerializer(invoices, many=True)
        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)
    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
    except Http404:
        return Response({"result": "error", "message": "No invoices found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["PATCH"])
def update_invoice(request):
    """
    Updates an invoice. Users can only update their own invoices while staff can update all invoices.
    """
    try:
        token = get_token(request)
        user = auth(token)

        reservation_id = request.GET.get("invoice")

        invoice = get_object_or_404(Invoice, pk=reservation_id)

        if invoice.reservation.customer.id != user.id:
            if not user.is_staff:
                raise AuthenticationFailed(f"Unauthenticated!")

        serializer = InvoiceSerializer(invoice, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response({"result": "success", "data": serializer.data}, status=status.HTTP_200_OK)

    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
    except Http404:
        return Response({"result": "error", "message": "No invoices found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(["DELETE"])
def delete_invoice(request):
    """
    Deletes an invoice. Only staff can delete invoices.
    """
    try:
        token = get_token(request)
        user = auth(token)

        reservation_id = request.GET.get("invoice")

        invoice = get_object_or_404(Invoice, pk=reservation_id)

        # Users cannot delete an invoices
        if not user.is_staff:
            raise AuthenticationFailed(f"Unauthenticated!")

        invoice.delete()
        return Response({"result": "success", "message": "Invoice deleted"}, status=status.HTTP_200_OK)

    except AuthenticationFailed as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_401_UNAUTHORIZED)
    except Http404:
        return Response({"result": "error", "message": "No invoices found"}, status=status.HTTP_404_NOT_FOUND)
    except ValidationError as e:
        return Response({"result": "error", "message": e.detail}, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"result": "error", "message": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

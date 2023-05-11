from datetime import datetime

from rest_framework import serializers
from .models import Reservation, Invoice


class ReservationSerializer(serializers.ModelSerializer):
    """
    Serializer for the Cabin model.
    """

    class Meta:
        model = Reservation
        fields = [
            "cabin",
            "customer",
            "owner",
            "services",
            "start_date",
            "end_date",
            "created_at",
            "canceled_at",
            "accepted_at",
        ]
        extra_kwargs = {
            "created_at": {"required": False},
            "canceled_at": {"required": False},
            "accepted_at": {"required": False},
        }

        read_only_fields = ["id", "updated_at"]

        def create(self, validated_data):
            instance = self.Meta.model(**validated_data)
            validated_data.pop("canceled_at", None)
            validated_data.pop("accepted_at", None)

            return instance

        def update(self, instance, validated_data):
            """
            Updates a reservation. Prevents updating some fields.
            :param instance: reservation object
            :param validated_data: reservation data
            :return: updated reservation object
            """
            if instance.canceled_at:
                raise serializers.ValidationError("Cannot update a canceled reservation")
            if instance.accepted_at and validated_data.get("accepted_at"):
                raise serializers.ValidationError("Cannot accept an already accepted reservation")
            if validated_data.get("created_at"):
                raise serializers.ValidationError("Cannot change the created_at field")

            if validated_data.get("canceled_at"):
                instance.canceled_at = datetime.now()
            if validated_data.get("accepted_at"):
                instance.accepted_at = datetime.now()

            instance.save()

            return instance


class InvoiceSerializer(serializers.ModelSerializer):
    """
    Serializer for the Invoice model.
    """
    customer = serializers.CharField(source='reservation.customer.username')
    reservation_id = serializers.CharField(source='reservation.id')
    reservation_cabin_area = serializers.CharField(source='reservation.cabin.area.area')


    class Meta:
        model = Invoice
        fields = [
            "reservation",
            "total_price",
            "paid_at",
            "created_at",
            "updated_at",
            "canceled_at",
            "customer",
            "reservation_id",
            "reservation_cabin_area",
        ]
        extra_kwargs = {
            "paid_at": {"required": False},
            "created_at": {"required": False},
            "updated_at": {"required": False},
            "canceled_at": {"required": False},
            "customer": {"required": False},
            "reservation_id": {"required": False},
            "reservation_cabin_area": {"required": False},
        }

        read_only_fields = ["id", "updated_at"]

        def update(self, instance, validated_data):
            """
            Updates an invoice. Prevents updating some fields.
            :param instance: invoice object
            :param validated_data: invoice data
            :return: updated invoice object
            """

            if instance.paid_at:
                raise serializers.ValidationError("Cannot update a paid invoice")
            if instance.cancelled_at:
                raise serializers.ValidationError("Cannot update a cancelled invoice")
            if validated_data.get("created_at"):
                raise serializers.ValidationError("Cannot change the created_at field")

            if validated_data.get("paid_at"):
                instance.paid_at = datetime.now()
            if validated_data.get("cancelled_at"):
                instance.cancelled_at = datetime.now()

            instance.save()

            return instance

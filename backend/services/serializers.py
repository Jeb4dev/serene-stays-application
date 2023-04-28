from rest_framework import serializers
from .models import Service

class ServiceSerializer(serializers.ModelSerializer):

    """Serializer for the Service model"""
    class Meta:
        model = Service
        fields = ['area', 'name', 'description', 'service_price', 'vat_price']
        id_fields = ['id', 'created_at', 'updated_at']


from rest_framework import serializers
from .models import Cabin, PostCode, AreaCode


class CabinSerializer(serializers.ModelSerializer):
    """
    Serializer for the Cabin model.
    """

    class Meta:
        model = Cabin
        fields = [
            "name",
            "description",
            "price_per_night",
            "area",
            "zip_code",
            "num_of_beds",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]

    def create(self, validated_data):
        instance = self.Meta.model(**validated_data)
        instance.save()
        return instance


class PostCodeSerializer(serializers.ModelSerializer):
    """
    Serializer for the PostCode model.
    """

    class Meta:
        model = PostCode
        fields = ["p_code", "postal_district"]
        read_only_fields = ["id", "created_at", "updated_at"]

    def create(self, validated_data):
        instance = self.Meta.model(**validated_data)
        instance.save()
        return instance


class AreaCodeSerializer(serializers.ModelSerializer):
    """
    Serializer for the AreaCode model.
    """

    class Meta:
        model = AreaCode
        fields = ["area", "post_code"]
        read_only_fields = ["id", "created_at", "updated_at"]

    def create(self, validated_data):
        instance = self.Meta.model(**validated_data)
        instance.save()
        return instance
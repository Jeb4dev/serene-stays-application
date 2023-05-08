from django.db import models


class Area(models.Model):
    area = models.CharField(max_length=100, primary_key=True)


class PostCode(models.Model):
    p_code = models.CharField(max_length=5, primary_key=True)
    postal_district = models.CharField(max_length=45)


class Cabin(models.Model):
    name = models.CharField(max_length=20)  # cabin name
    description = models.TextField(max_length=255)  # freeform description of the cabin
    price_per_night = models.DecimalField(max_digits=8, decimal_places=2)  # renting price
    area = models.ForeignKey(Area, on_delete=models.CASCADE)
    zip_code = models.ForeignKey(PostCode, on_delete=models.CASCADE)
    num_of_beds = models.IntegerField()
    address = models.CharField(max_length=100, null=True)

    def __str__(self):
        return self.name

from django.db import models

from cabins.models import Area


class Service(models.Model):
    area = models.ForeignKey(Area, on_delete=models.CASCADE)
    name = models.CharField(max_length=30)
    description = models.CharField(max_length=255)
    service_price = models.DecimalField(max_digits=5, decimal_places=2)
    vat_price = models.DecimalField(max_digits=5, decimal_places=2)

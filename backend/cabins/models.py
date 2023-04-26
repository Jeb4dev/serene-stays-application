from django.db import models

class AreaCode(models.Model):
    area = models.CharField(max_length=100)
    post_code = models.CharField(max_length=10)

class PostCode(models.Model):
    p_code = models.ForeignKey(AreaCode, on_delete = models.CASCADE)
    postal_district = models.CharField(max_length = 45)
    
class Cabin(models.Model):
    name = models.CharField(max_length = 20) # cabin name
    description = models.TextField(max_length = 255) # freeform description of the cabin
    price_per_night = models.DecimalField(max_digits = 8, decimal_places = 2) # renting price
    area = models.ForeignKey(AreaCode, on_delete = models.CASCADE)
    num_of_beds = models.IntegerField()

    def __str__(self):
        return self.name
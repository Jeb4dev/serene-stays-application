from django.contrib import admin

from .models import Reservation, Invoice

admin.site.register(Reservation)
admin.site.register(Invoice)

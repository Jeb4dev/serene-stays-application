from django.urls import path
from .views import create_reservation, get_reservations, update_reservation, delete_reservation
from .views import create_invoice, get_invoices, update_invoice, delete_invoice

urlpatterns = [
    path('create', create_reservation, name='create_reservation'),
    path('', get_reservations, name='get_reservations'),
    path('update', update_reservation, name='update_reservation'),
    path('delete', delete_reservation, name='delete_reservation'),
    path('invoice/create', create_invoice, name='create_invoice'),
    path('invoice', get_invoices, name='get_invoices'),
    path('invoice/update', update_invoice, name='update_invoice'),
    path('invoice/delete', delete_invoice, name='delete_invoice'),
]

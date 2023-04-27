from django.shortcuts import render
from rest_framework.decorators import api_view


# Create your views here.


@api_view(["POST"])
def create_reservation(self):
    """
    Creates a new reservation.
    """
    pass
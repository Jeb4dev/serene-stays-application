from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    """
    User model represents a customer or a staff member.
    """

    email = models.EmailField(max_length=150, unique=True, null=False, blank=False)
    phone = models.CharField(max_length=15, null=True)
    address = models.CharField(max_length=150, null=True)
    zip = models.CharField(max_length=5, null=True)

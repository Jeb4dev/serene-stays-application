from django.db import models


class Reservation(models.Model):
    """
    User model represents a customer or a staff member.
    """

    cabin = models.ForeignKey("cabins.Cabin", on_delete=models.CASCADE)
    customer = models.ForeignKey("users.User", on_delete=models.CASCADE)
    owner = models.ForeignKey("users.User", on_delete=models.CASCADE)
    start_date = models.DateField(null=False, blank=False)
    end_date = models.DateField(null=False, blank=False)
    created_at = models.DateTimeField(auto_now_add=True)  # When the reservation was created by the customer
    accepted_at = models.DateTimeField(null=True)  # When the reservation was accepted by the owner or staff
    canceled_at = models.DateTimeField(null=True)  # When the reservation was canceled by the customer or staff

    def __str__(self):
        return f"{self.cabin} {self.customer} {self.start_date} {self.end_date}"

    def get_total_cabin_price(self) -> tuple:
        """
        Returns the total price of the cabin for the reservation period.
        :return: tuple (total price, total price with VAT)
        """
        return 0, 0

    def get_total_services_price(self) -> tuple:
        """
        Returns the total price of the services for the reservation period.
        :return: tuple (total price, total price with VAT)
        """
        return 0, 0

    def get_services(self) -> list:
        """
        Returns all the services that are included in the reservation.
        """
        return []


class Invoice(models.Model):
    reservation = models.ForeignKey("reservations.Reservation", on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)  # When the invoice was created
    paid_at = models.DateTimeField(null=True)  # When the invoice was paid
    canceled_at = models.DateTimeField(null=True)  # When the invoice was canceled

    def __str__(self):
        return f"{self.reservation}"

    def get_invoice(self) -> str:
        """
        Returns the invoice in PDF format.
        """
        invoice = ""
        return invoice

from datetime import datetime
from django.db import models
from django.db.models import Q
from users.models import User
from cabins.models import Cabin
from services.models import Service
from django.core.exceptions import ValidationError


class Reservation(models.Model):
    """
    Model for a reservation of a cabin.
    """

    cabin = models.ForeignKey(Cabin, on_delete=models.CASCADE)
    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name="customer")
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name="owner")
    services = models.ManyToManyField(Service, blank=True)
    start_date = models.DateField(null=False, blank=False)
    end_date = models.DateField(null=False, blank=False)
    created_at = models.DateTimeField(auto_now_add=True)  # When the reservation was created by the customer
    accepted_at = models.DateTimeField(null=True, blank=True)  # When the reservation was accepted by the owner or staff
    canceled_at = models.DateTimeField(null=True, blank=True)  # When the reservation was canceled by the customer or staff

    def __str__(self):
        return f"{self.cabin} {self.customer} {self.start_date} {self.end_date}"
    
    # Q object to query the database for any reservations that overlap the new reservation.
    def clean(self):
        super().clean()
        overlapping_reservations = Reservation.objects.filter(
            Q(start_date__range=(self.start_date, self.end_date)) |
            Q(end_date__range=(self.start_date, self.end_date)) |
            Q(start_date__lte=self.start_date, end_date__gte=self.end_date)
        ).exclude(pk=self.pk)
        if overlapping_reservations.exists():
            raise ValidationError({'__all__': ['Reservation overlaps with an existing booking.']})

    @property
    def length_of_stay(self) -> int:
        start = datetime.strptime(self.start_date.__str__(), "%Y-%m-%d")
        end = datetime.strptime(self.end_date.__str__(), "%Y-%m-%d")
        return (end - start).days

    def get_total_cabin_price(self) -> float:
        """
        Returns the total price of the cabin for the reservation period.
        """
        price = self.cabin.price_per_night * self.length_of_stay
        return price

    def get_total_services_price(self) -> float:
        """
        Returns the total price of the services for the reservation period.
        """
        price = 0
        for service in self.services.all():
            price += service.service_price
        return price

    def get_total_price(self) -> float:
        """
        Returns the total price of the reservation.
        """
        price = self.get_total_cabin_price() + self.get_total_services_price()
        return price

    def get_services(self) -> list:
        """
        Returns all the services that are included in the reservation.
        """
        services = []
        for service in self.services.all():
            services.append((service.name, service.service_price))
        return services
    
    def is_cabin_available(cabin, check_in_date, check_out_date):
        """
        Checks if given cabin is available for the specified
        check-in and check-out dates.
        : param cabin: Cabin object
        : param check_in_date: Check-in date
        : param check_out_date: Check-out date
        :return True if the cabin is available, otherwise False
        """
        if check_in_date >= check_out_date:
            return False
        overlapping_reservations = Reservation.objects.filter(
            cabin=cabin,
            start_date__lt=check_out_date,
            end_date__gt=check_in_date
        )
        return not overlapping_reservations.exists()


class Invoice(models.Model):
    """
    Model for an invoice for a reservation.
    """
    reservation = models.ForeignKey(Reservation, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)  # When the invoice was created
    paid_at = models.DateTimeField(null=True, blank=True)  # When the invoice was paid
    canceled_at = models.DateTimeField(null=True, blank=True)  # When the invoice was canceled
    updated_at = models.DateTimeField(auto_now=True, blank=True)  # When the invoice was last updated

    def __str__(self):
        return f"{self.reservation}"

    @property
    def total_price(self) -> tuple:
        """
        Returns the total price of the reservation.
        """
        total_price = self.reservation.get_total_cabin_price() + self.reservation.get_total_services_price()
        return total_price

    def get_invoice(self) -> str:
        """
        Returns the invoice in PDF format.
        """

        # Create pdf file in html format

        html = f"""
        <html>
            <head>
                <title>Invoice</title>
            </head>
            <body>
                <div>
                    <h1>Invoice</h1>
                    <h2>Reservation</h2>
                    <p>Customer: {self.reservation.customer}</p>
                    <p>Owner: {self.reservation.owner}</p>
                    <p>Cabin: {self.reservation.cabin}</p>
                    <p>Services: {self.reservation.get_services()}</p>
                    <p>Check-in date: {self.reservation.start_date}</p>
                    <p>Check-out date: {self.reservation.end_date}</p>
                    <p>Total price: {self.total_price}</p>
                </div>
            </body>
        </html>
        """
        return html


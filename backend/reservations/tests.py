from django.test import TestCase

from services.models import Service
from .models import Reservation, Invoice
from cabins.models import Cabin, AreaCode, PostCode
from users.models import User


# Create your tests here.


class TestReservation(TestCase):
    def setUp(self) -> None:
        self.area = AreaCode.objects.create(area="Helsinki", post_code="00100")
        self.post = PostCode.objects.create(p_code=self.area, postal_district="Helsinki")
        self.cabin = Cabin.objects.create(
            name="Test Cabin",
            description="Test Cabin",
            price_per_night=100,
            area=self.area,
            zip_code=self.post,
            num_of_beds=4,
        )
        self.customer = User.objects.create_user(username="JohnD", email="johndoe.example.com", password="password")
        self.owner = User.objects.create_user(username="JaneD", email="janedoe.example.com", password="password")
        self.services = []
        sauna = Service.objects.create(area=self.area, name="Sauna", description="Sauna", service_price=10, vat_price=2)
        hot_tub = Service.objects.create(
            area=self.area, name="Hot Tub", description="Hot Tub", service_price=20, vat_price=4
        )
        self.services.append(sauna)
        self.services.append(hot_tub)

    def test_create_reservation(self):
        """
        Tests that a reservation can be created.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-02"
        )
        self.reservation.services.add(self.services[1])

        self.assertEqual(self.reservation.cabin, self.cabin)
        self.assertEqual(self.reservation.customer, self.customer)
        self.assertEqual(self.reservation.owner, self.owner)
        self.assertEqual(self.reservation.start_date, "2021-01-01")
        self.assertEqual(self.reservation.end_date, "2021-01-02")
        self.assertEqual(self.reservation.services.all()[0], self.services[1])

    def test_calculate_length_of_stay(self):
        """
        Tests that the length of stay is calculated correctly.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-02"
        )
        self.assertEqual(self.reservation.length_of_stay, 1)
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-03"
        )
        self.assertEqual(self.reservation.length_of_stay, 2)
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-02-04"
        )
        self.assertEqual(self.reservation.length_of_stay, 34)

    def test_calculate_price_of_cabin(self):
        """
        Tests that the price of the cabin is calculated correctly.
        """

        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-02"
        )
        expected_price = self.reservation.length_of_stay * self.cabin.price_per_night
        self.assertEqual(self.reservation.get_total_cabin_price(), expected_price)
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-03"
        )
        expected_price = self.reservation.length_of_stay * self.cabin.price_per_night
        self.assertEqual(self.reservation.get_total_cabin_price(), expected_price)

    def test_calculate_price_of_services(self):
        """
        Tests that the price of the services is calculated correctly.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-02"
        )
        self.reservation.services.add(self.services[0])
        expected_price = self.services[0].service_price
        self.assertEqual(self.reservation.get_total_services_price(), expected_price)
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-03"
        )
        self.reservation.services.add(self.services[1])
        expected_price = self.services[1].service_price
        self.assertEqual(self.reservation.get_total_services_price(), expected_price)

    def test_calculate_total_price_of_reservation(self):
        """
        Tests that the total price of the reservation is calculated correctly.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-02"
        )
        self.reservation.services.add(self.services[0])
        expected_price = (
            self.reservation.cabin.price_per_night * self.reservation.length_of_stay
            + self.reservation.services.all()[0].service_price
        )
        self.assertEqual(self.reservation.get_total_price(), expected_price)
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-03"
        )
        self.reservation.services.add(self.services[1])
        expected_price = (
            self.reservation.cabin.price_per_night * self.reservation.length_of_stay + self.services[1].service_price
        )
        self.assertEqual(self.reservation.get_total_price(), expected_price)


class TestInvoice(TestCase):
    def setUp(self) -> None:
        self.area = AreaCode.objects.create(area="Helsinki", post_code="00100")
        self.post = PostCode.objects.create(p_code=self.area, postal_district="Helsinki")
        self.cabin = Cabin.objects.create(
            name="Test Cabin",
            description="Test Cabin",
            price_per_night=100,
            area=self.area,
            zip_code=self.post,
            num_of_beds=4,
        )
        self.customer = User.objects.create_user(username="JohnD", email="johndoe.example.com", password="password")
        self.owner = User.objects.create_user(username="JaneD", email="janedoe.example.com", password="password")
        self.services = []
        sauna = Service.objects.create(area=self.area, name="Sauna", description="Sauna", service_price=10, vat_price=2)
        hot_tub = Service.objects.create(
            area=self.area, name="Hot Tub", description="Hot Tub", service_price=20, vat_price=4
        )
        self.services.append(sauna)
        self.services.append(hot_tub)

    def test_create_invoice(self):
        """
        Tests that the invoice is created correctly.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin, customer=self.customer, owner=self.owner, start_date="2021-01-01", end_date="2021-01-02"
        )
        self.reservation.services.add(self.services[1])
        self.invoice = Invoice.objects.create(reservation=self.reservation)
        self.assertEqual(self.invoice.reservation, self.reservation)
        self.assertEqual(self.invoice.total_price, self.reservation.get_total_price())

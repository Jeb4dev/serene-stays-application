from datetime import date, timedelta
from io import BytesIO

from django.core.exceptions import ValidationError
from django.test import TestCase
from reportlab.pdfgen import canvas

from cabins.models import Cabin, Area, PostCode
from services.models import Service
from users.models import User
from .models import Reservation, Invoice


# Create your tests here.


class TestReservation(TestCase):
    def setUp(self) -> None:
        self.area = Area.objects.create(area="Helsinki")
        self.post = PostCode.objects.create(p_code="10110", postal_district="Helsinki")
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

    def test_cannot_book_already_booked(self):
        # Create a reservation for the cabin
        start_date = date.today() + timedelta(days=7)
        end_date = date.today() + timedelta(days=10)
        Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=start_date,
            end_date=end_date,
        )
        # create a new reservation that overlaps with the existing
        new_start_date = start_date + timedelta(days=1)
        new_end_date = end_date + timedelta(days=1)
        # print(f"Existing reservation: {reservation.start_date} - {reservation.end_date}")
        # print(f"New reservation: {new_start_date} - {new_end_date}")
        new_reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=new_start_date,
            end_date=new_end_date,
        )
        with self.assertRaises(ValidationError) as cm:
            new_reservation.clean()
        self.assertDictEqual({"__all__": ["Reservation overlaps with an existing booking."]}, cm.exception.message_dict)

    def test_is_cabin_available(self):
        # Is the cabin available for the date range that doesn't
        # overlap with the existing reservation.
        available = Reservation.is_cabin_available(
            self.cabin, date.today() + timedelta(days=5), date.today() + timedelta(days=6)
        )
        self.assertTrue(available)

    # def test_cabin_not_available(self):
    #     # Test if the cabin isn't available for the specified date range, that overlaps
    #     # with an existing reservation.
    #     available = Reservation.is_cabin_available(self.cabin, check_in_date=,
    #                                                 check_out_date=)
    #     self.assertFalse(available)

    def test_invalid_date_range(self):
        # Test that the method returns false when check-in date is after check-out date
        available = Reservation.is_cabin_available(
            self.cabin, date.today() + timedelta(days=6), date.today() + timedelta(days=5)
        )
        self.assertFalse(available)

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
        self.area = Area.objects.create(area="Helsinki")
        self.post = PostCode.objects.create(p_code="10110", postal_district="Helsinki")
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

    def test_get_invoice(self):
        start_date = date.today() + timedelta(days=7)
        end_date = date.today() + timedelta(days=10)
        reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=start_date,
            end_date=end_date,
        )
        invoice = Invoice.objects.create(reservation=reservation)

        # generate the invoice PDF
        response = invoice.get_invoice()

        # Check the response status code
        self.assertEqual(response.status_code, 200)

        # Check response content type
        self.assertEqual(response["Content-Type"], "application/pdf")

        # Check the response file name
        self.assertEqual(response["Content-Disposition"], 'attachment; filename="invoice.pdf"')

        # Validate the PDF content
        buffer = BytesIO()
        p = canvas.Canvas(buffer)

        # Check the PDF content
        # self.assertEqual(p.getPageNumber(), 1)

        p.showPage()
        p.save()
        buffer.seek(0)

        pdf_content = buffer.getvalue()
        self.assertGreater(len(pdf_content), 0)
        buffer.close()

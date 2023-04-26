from django.test import TestCase
from .models import Reservation
from cabins.models import Cabin, AreaCode, PostCode
from users.models import User


# Create your tests here.


class TestReservation(TestCase):

    def create_required_objects(self) -> tuple:
        """
        Creates a test area, customer, owner and a cabin.
        :return: customer: User, owner: User, cabin: Cabin
        """
        area = AreaCode.objects.create(area="Tahko", post_code="10100")
        cabin = Cabin.objects.create(name="Korpikartano", description="A luxurious villa with a sauna and a hot tub.",
                                     price_per_night=10, area=area, num_of_beds=1)
        customer = User.objects.create_user(username="JariA", email="jariaarni@mail.com", password="test")
        owner = User.objects.create_user(username="KaiKo", email="kaikorpi@email.com", password="test")
        return customer, owner, cabin

    def test_reservation(self):
        """
        Tests that a reservation can be created.
        """
        customer, owner, cabin = self.create_required_objects()
        reservation = Reservation.objects.create(
            cabin=cabin, customer=customer, owner=owner, start_date="2020-01-01", end_date="2020-01-04"
        )
        self.assertEqual(reservation.cabin, cabin, "Reservation cabin does not match the cabin.")
        self.assertEqual(reservation.customer, customer, "Reservation customer does not match the customer.")
        self.assertEqual(reservation.owner, owner, "Reservation owner does not match the owner.")
        self.assertEqual(reservation.start_date, "2020-01-01", "Reservation start date does not match the start date.")
        self.assertEqual(reservation.end_date, "2020-01-04", "Reservation end date does not match the end date.")
        self.assertEqual(reservation.length_of_stay, 3, "Reservation length of stay does not match the length of stay.")

    def test_get_total_cabin_price(self):
        """
        Tests that the total cabin price is calculated correctly.
        """
        customer, owner, cabin = self.create_required_objects()
        reservation = Reservation.objects.create(
            cabin=cabin, customer=customer, owner=owner, start_date="2020-01-01", end_date="2020-01-04"
        )
        self.assertEqual(reservation.get_total_cabin_price(), (30, 37.2), "Total cabin price is not calculated correctly.")

    def test_get_total_services_price(self):
        """
        Tests that the total services price is calculated correctly.
        """
        pass
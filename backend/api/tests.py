import datetime
import json

from rest_framework.test import APIClient, APITestCase
from rest_framework import status

from cabins.models import Area, PostCode, Cabin
from reservations.models import Reservation, Invoice
from services.models import Service
from users.models import User


# Create your tests here.

class TestCabinApi(APITestCase):

    def setUp(self) -> None:
        self.owner = User.objects.create_user(username="owner", password="owner", email="email@email.com")
        self.customer = User.objects.create_user(username="customer", password="customer", email="email@hotmail.com")
        self.area = Area.objects.create(area="Helsinki")
        self.post = PostCode.objects.create(p_code="10110", postal_district="Helsinki")

    def test_cabin_creation(self):
        """
        Tests that a cabin can be created.
        """

        data = {
            "name": "Test Cabin",
            "description": "Test Cabin",
            "price_per_night": 100,
            "area": self.area.area,
            "zip_code": self.post.p_code,
            "num_of_beds": 4,
        }

        response = self.client.post("/api/area/cabins/create", data)

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["name"], data["name"])
        self.assertEqual(response.data["data"]["description"], data["description"])
        self.assertEqual(response.data["data"]["price_per_night"], format(float(data["price_per_night"]), ".2f"))
        self.assertEqual(response.data["data"]["area"], data["area"])
        self.assertEqual(response.data["data"]["zip_code"], data["zip_code"])
        self.assertEqual(response.data["data"]["num_of_beds"], data["num_of_beds"])

    def create_dummy_data(self):
        """
        Creates dummy cabins for testing purposes.
        """
        # Create 5 different areas:
        areas = []
        for i in range(1, 6):
            areas.append(Area.objects.create(area=f"Area {i}"))

        # Create 5 different post codes:
        post_codes = []
        for i in range(1, 6):
            post_codes.append(PostCode.objects.create(p_code=areas[i - 1], postal_district=f"District {i}"))

        # Create 10 different cabins:
        cabins = []
        for i in range(1, 11):
            response = self.client.post("/api/area/cabins/create", {
                "name": f"Cabin {i}",
                "description": f"Cabin {i}",
                "price_per_night": 100,
                "area": areas[i // 2 - 1].area,
                "zip_code": post_codes[i // 2 - 1].p_code,
                "num_of_beds": 4,
            })
            self.assertEqual(response.status_code, 201)
            cabins.append(i)

        # Create 5 different services:
        services = []

        return cabins, services, areas, post_codes

    def test_cabin_search(self):
        """
        Tests that the cabin search works.
        """
        cabins, services, areas, post_codes = self.create_dummy_data()

        # Test that all cabins are returned when no search parameters are given:
        response = self.client.get("/api/area/cabins")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 10)

        # Test that the correct number of cabins are returned when a search parameter is given:
        response = self.client.get("/api/area/cabins", {"area": areas[0].area})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

        # Test that the correct number of cabins are returned when searched by zip code:
        response = self.client.get("/api/area/cabins", {"zip_code": post_codes[0].p_code})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

        # Test that the correct number of cabins are returned when searched by number of beds:
        response = self.client.get("/api/area/cabins", {"num_of_beds": 4})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 10)

        # Test that the correct number of cabins are returned when searched by zip code and area:
        response = self.client.get("/api/area/cabins", {"area": areas[0].area, "zip_code": post_codes[0].p_code})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

        # Test that the correct number of cabins are returned when searched by zip code, area and number of beds:
        response = self.client.get("/api/area/cabins",
                                   {"area": areas[0].area, "zip_code": post_codes[0].p_code, "num_of_beds": 4})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

    def test_search_by_id(self):
        """
        Tests that a cabin can be searched by id.
        """
        cabins, services, areas, post_codes = self.create_dummy_data()

        for cabin in cabins:
            response = self.client.get(f"/api/area/cabins", {"id": cabin})
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data["data"]["name"], f"Cabin {cabin}")

    def test_update_cabin_info(self):
        """
        Tests that a cabin's info can be updated.
        """
        cabins, services, areas, post_codes = self.create_dummy_data()

        for cabin in cabins:
            response = self.client.patch(f"/api/area/cabins/update?id={cabin}", json.dumps({
                "name": f"New Cabin {cabin}",
                "description": f"New Cabin desc {cabin}",
                "price_per_night": 120.00,
                "area": str(areas[2].area),
                "zip_code": str(post_codes[2].p_code),
                "num_of_beds": 6
            }), content_type='application/json')
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data["data"]["name"], f"New Cabin {cabin}")
            self.assertEqual(response.data["data"]["description"], f"New Cabin desc {cabin}")
            self.assertEqual(response.data["data"]["price_per_night"], format(float(120.00), '.2f'))
            self.assertEqual(response.data["data"]["area"], str(areas[2].area))
            self.assertEqual(response.data["data"]["zip_code"], str(post_codes[2].p_code))
            self.assertEqual(response.data["data"]["num_of_beds"], 6)

            # Search for the updated cabin:
            response = self.client.get(f"/api/area/cabins", {"id": cabin})
            self.assertEqual(response.status_code, 200)
            self.assertEqual(response.data["data"]["name"], f"New Cabin {cabin}")

    def test_delete_cabin(self):
        """
        Tests cabin deletion
        """
        cabins, services, areas, post_codes = self.create_dummy_data()

        for cabin in cabins:
            response = self.client.delete(f"/api/area/cabins/delete?id={cabin}")
            self.assertEqual(response.status_code, 200)

            # Search for the deleted cabin:
            response = self.client.get(f"/api/area/cabins", {"id": cabin})
            self.assertEqual(response.status_code, 404)


class TestAreaApi(APITestCase):

    def test_area_creation(self):
        """
        Tests that an area can be created.
        """
        data = {
            "area": "Helsinki",
        }
        response = self.client.post("/api/area/create", data)
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["area"], data["area"])

    def test_area_search(self):
        """
        Tests that an area can be searched.
        """
        data = {
            "area": "Helsinki",
        }
        response = self.client.post("/api/area/create", data)
        self.assertEqual(response.status_code, 201)

        response = self.client.get(f"/api/area/?area{data['area']}")
        self.assertEqual(response.status_code, 200)
        response_data = data = [dict(item) for item in response.data["data"]]
        self.assertEqual(response_data, data)

    def test_area_update(self):
        """
        Tests that an area can be updated.
        """
        data = {
            "area": "Helsinki",
        }
        response = self.client.post("/api/area/create", data)
        self.assertEqual(response.status_code, 201)

        new_data = {
            "area": "Malmi",
        }
        response = self.client.patch(f"/api/area/update?area={data['area']}", json.dumps(new_data), content_type="application/json")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["area"], new_data["area"])

    def test_area_delete(self):
        """
        Tests that an area can be deleted.
        """
        data = {
            "area": "Helsinki",
        }
        response = self.client.post("/api/area/create", data)
        self.assertEqual(response.status_code, 201)

        response = self.client.delete(f"/api/area/delete?area={data['area']}")
        self.assertEqual(response.status_code, 200)

        response = self.client.get(f"/api/area/?area={data['area']}")
        self.assertEqual(response.status_code, 404)


class TestInvoiceApi(APITestCase):

    def setUp(self):
        self.client = APIClient()

        self.owner = User.objects.create_user(username="owner", password="owner", email="owner@email.com")
        self.customer = User.objects.create_user(username="customer", password="customer", email="customer@email.com")

        self.area = Area.objects.create(area="Helsinki")
        self.post_code = PostCode.objects.create(p_code="00100", postal_district="Helsinki")

        self.cabin = Cabin.objects.create(
            name="Cabin 1",
            description="Cabin 1 description",
            price_per_night=100.00,
            area=self.area,
            zip_code=self.post_code,
            num_of_beds=4
        )

        service = Service.objects.create(area=self.area, name="Sauna", description="Hot cabin", service_price=10,
                                         vat_price=2)

        self.reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=datetime.date.today(),
            end_date=datetime.date.today() + datetime.timedelta(days=2),
        )

        self.reservation.services.add(service)


class TestReservationApi(APITestCase):

    def setUp(self):
        self.owner = User.objects.create_user(username="owner", password="owner", email="owner@email.com")
        self.customer = User.objects.create_user(username="customer", password="customer", email="customer@email.com")

        self.area = Area.objects.create(area="Helsinki")
        self.post_code = PostCode.objects.create(p_code="00100", postal_district="Helsinki")

        self.cabin = Cabin.objects.create(
            name="Cabin 1",
            description="Cabin 1 description",
            price_per_night=100.00,
            area=self.area,
            zip_code=self.post_code,
            num_of_beds=4
        )

        self.service = Service.objects.create(area=self.area, name="Sauna", description="Hot cabin", service_price=10,
                                              vat_price=2)

        response = self.client.post("/api/user/login", {
            "email": "customer@email.com",
            "password": "customer",
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.token = response.data.pop("jwt")
        self.assertTrue(self.token)

    def test_reservation_create(self):
        """
        Tests that a reservation can be created.
        """

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.token}")

        response = self.client.post("/api/reservation/create", {
            "cabin": self.cabin.id,
            "customer": self.customer.id,
            "owner": self.owner.id,
            "start_date": datetime.date.today(),
            "end_date": datetime.date.today() + datetime.timedelta(days=2),
            "services": [self.service.id]
        })

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["data"]["cabin"], self.cabin.id)
        self.assertEqual(response.data["data"]["customer"], self.customer.id)
        self.assertEqual(response.data["data"]["owner"], self.owner.id)
        self.assertEqual(response.data["data"]["start_date"], str(datetime.date.today()))
        self.assertEqual(response.data["data"]["end_date"], str(datetime.date.today() + datetime.timedelta(days=2)))

        self.reservation = Reservation.objects.all().first()
        self.assertEqual(self.reservation.cabin, self.cabin)
        self.assertEqual(self.reservation.customer, self.customer)
        self.assertEqual(self.reservation.owner, self.owner)
        self.assertEqual(self.reservation.start_date, datetime.date.today())
        self.assertEqual(self.reservation.end_date, datetime.date.today() + datetime.timedelta(days=2))
        self.assertEqual(list(self.reservation.services.all()), [self.service])
        self.assertEqual(str(self.reservation.get_total_price()), format(210, '.2f'))
        self.assertEqual(self.reservation.length_of_stay, 2)

    def test_reservation_get(self):
        """
        Tests that a reservation can be retrieved.
        """
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.token}")
        self.reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=datetime.date.today(),
            end_date=datetime.date.today() + datetime.timedelta(days=2),
        )

        response = self.client.get(f"/api/reservation/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"][0]["cabin"], self.cabin.id)
        self.assertEqual(response.data["data"][0]["customer"], self.customer.id)
        self.assertEqual(len(response.data["data"]), 1)

    def test_reservation_search(self):
        """
        Tests that a reservation can be searched.
        """
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.token}")
        self.reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=datetime.date.today(),
            end_date=datetime.date.today() + datetime.timedelta(days=2),
        )

        response = self.client.get(f"/api/reservation/?reservation={self.reservation.id}")
        self.assertEqual(response.status_code, 200)

    def test_reservation_update(self):
        """
        Tests that a reservation can be updated.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=datetime.date.today(),
            end_date=datetime.date.today() + datetime.timedelta(days=2),
        )
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.token}")

        response = self.client.patch(f"/api/reservation/update?reservation={self.reservation.id}", json.dumps({
            "start_date": str(datetime.date.today() + datetime.timedelta(days=1)),
            "end_date": str(datetime.date.today() + datetime.timedelta(days=3)),
        }), content_type='application/json')

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"]["start_date"], str(datetime.date.today() + datetime.timedelta(days=1)))
        self.assertEqual(response.data["data"]["end_date"], str(datetime.date.today() + datetime.timedelta(days=3)))

        # Check that the reservation was updated

        response = self.client.get(f"/api/reservation/?reservation={self.reservation.id}")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["data"][0]["start_date"],
                         str(datetime.date.today() + datetime.timedelta(days=1)))
        self.assertEqual(response.data["data"][0]["end_date"], str(datetime.date.today() + datetime.timedelta(days=3)))

    def test_reservation_update_not_found(self):
        """
        Tests updating a reservation that does not exist.
        """
        response = self.client.patch(f"/api/reservation/update?reservation=1", {
            "start_date": datetime.date.today() + datetime.timedelta(days=1),
            "end_date": datetime.date.today() + datetime.timedelta(days=3),
        }, content_type='application/json')

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["message"], "No reservations found")

    def test_reservation_delete(self):
        """
        Tests that a reservation can be deleted.
        """
        self.reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=datetime.date.today(),
            end_date=datetime.date.today() + datetime.timedelta(days=2),
        )

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.token}")

        response = self.client.delete(f"/api/reservation/delete?reservation={self.reservation.id}")
        self.assertEqual(response.status_code, 200)

        # Check that the reservation was deleted
        response = self.client.get(f"/api/reservation/?reservation={self.reservation.id}")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["message"], "No reservations found")

    def test_reservation_delete_not_found(self):
        """
        Tests deleting a reservation that does not exist.
        """
        response = self.client.delete(f"/api/reservation/delete?reservation=1")
        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.data["message"], "No reservations found")

    def test_reservation_delete_no_id(self):
        """
        Tests deleting a reservation without an id.
        """
        response = self.client.delete(f"/api/reservation/delete")
        self.assertEqual(response.status_code, 400)

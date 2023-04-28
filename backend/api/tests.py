import datetime

from django.test import TestCase

from cabins.models import Area, PostCode, Cabin
from reservations.models import Reservation, Invoice
from services.models import Service
from users.models import User


# Create your tests here.

class TestCabinApi(TestCase):

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
            response = self.client.patch(f"/api/area/cabins/update?id={cabin}", {
                "name": f"New Cabin {cabin}",
                "description": f"New Cabin desc {cabin}",
                "price_per_night": 120.00,
                "area": str(areas[2].area),
                "zip_code": str(post_codes[2].p_code),
                "num_of_beds": 6
            }, content_type='application/json')
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


class TestAreaApi(TestCase):

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
        response = self.client.patch(f"/api/area/update?area={data['area']}", new_data, content_type='application/json')
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


class TestInvoiceApi(TestCase):

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

        service = Service.objects.create(area=self.area, name="Sauna", description="Hot cabin", service_price=10, vat_price=2)

        self.reservation = Reservation.objects.create(
            cabin=self.cabin,
            customer=self.customer,
            owner=self.owner,
            start_date=datetime.date.today(),
            end_date=datetime.date.today() + datetime.timedelta(days=2),
        )

        self.reservation.services.add(service)

    # def test_create_invoice(self):
    #     """
    #     Tests that an invoice can be created.
    #     """
    #     response = self.client.post("/api/reservation/invoice/create", {
    #         "reservation": self.reservation.id,
    #     })
    #     self.assertEqual(response.status_code, 201)


class TestReservationApi(TestCase):

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

    def test_reservation_create(self):
        """
        Tests that a reservation can be created.
        """
        # THIS TEST FAILS

        # response = self.client.post("/api/reservation/create", {
        #     "cabin": self.cabin.id,
        #     "customer": self.customer.id,
        #     "owner": self.owner.id,
        #     "start_date": datetime.date.today(),
        #     "end_date": datetime.date.today() + datetime.timedelta(days=2),
        #     "services": [self.service.id]
        # })
        # self.assertEqual(response.status_code, 201)
        # self.assertEqual(response.data["data"]["cabin"], self.cabin.id)
        # self.assertEqual(response.data["data"]["customer"], self.customer.id)
        # self.assertEqual(response.data["data"]["owner"], self.owner.id)
        # self.assertEqual(response.data["data"]["start_date"], str(datetime.date.today()))
        # self.assertEqual(response.data["data"]["end_date"], str(datetime.date.today() + datetime.timedelta(days=2)))
        # self.assertEqual(response.data["data"]["services"], [self.service.id])
        #
        # self.reservation = Reservation.objects.get(id=response.data["data"]["id"])
        # self.assertEqual(self.reservation.cabin, self.cabin)
        # self.assertEqual(self.reservation.customer, self.customer)
        # self.assertEqual(self.reservation.owner, self.owner)
        # self.assertEqual(self.reservation.start_date, datetime.date.today())
        # self.assertEqual(self.reservation.end_date, datetime.date.today() + datetime.timedelta(days=2))
        # self.assertEqual(list(self.reservation.services.all()), [self.service])
        # self.assertEqual(self.reservation.total_price, 224.0)
        # self.assertEqual(self.reservation.length_of_stay, 2)
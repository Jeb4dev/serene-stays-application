from django.test import TestCase

from cabins.models import AreaCode, PostCode
from services.models import Service
from users.models import User


# Create your tests here.

class TestCabinApi(TestCase):

    def setUp(self) -> None:
        self.owner = User.objects.create_user(username="owner", password="owner", email="email@email.com")
        self.customer = User.objects.create_user(username="customer", password="customer", email="email@hotmail.com")
        self.area = AreaCode.objects.create(area="Helsinki", post_code="00100")
        self.post = PostCode.objects.create(p_code=self.area, postal_district="Helsinki")

    def test_cabin_creation(self):
        """
        Tests that a cabin can be created.
        """

        data = {
            "name": "Test Cabin",
            "description": "Test Cabin",
            "price_per_night": 100,
            "area": self.area.id,
            "zip_code": self.post.id,
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
            areas.append(AreaCode.objects.create(area=f"Area {i}", post_code=f"00{i}00"))

        # Create 5 different post codes:
        post_codes = []
        for i in range(1, 6):
            post_codes.append(PostCode.objects.create(p_code=areas[i-1], postal_district=f"District {i}"))

        # Create 10 different cabins:
        cabins = []
        for i in range(1, 11):
            response = self.client.post("/api/area/cabins/create", {
                "name": f"Cabin {i}",
                "description": f"Cabin {i}",
                "price_per_night": 100,
                "area": areas[i//2-1].id,
                "zip_code": post_codes[i//2-1].id,
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
        response = self.client.get("/api/area/cabins", {"area": areas[0].id})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

        # Test that the correct number of cabins are returned when searched by zip code:
        response = self.client.get("/api/area/cabins", {"zip_code": post_codes[0].id})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

        # Test that the correct number of cabins are returned when searched by number of beds:
        response = self.client.get("/api/area/cabins", {"num_of_beds": 4})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 10)

        # Test that the correct number of cabins are returned when searched by zip code and area:
        response = self.client.get("/api/area/cabins", {"area": areas[0].id, "zip_code": post_codes[0].id})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.data["data"]), 2)

        # Test that the correct number of cabins are returned when searched by zip code, area and number of beds:
        response = self.client.get("/api/area/cabins", {"area": areas[0].id, "zip_code": post_codes[0].id, "num_of_beds": 4})
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


class TestAreaApi(TestCase):

    def test_area_creation(self):
        """
        Tests that an area can be created.
        """
        pass
        # data = {
        #     "area": "Helsinki",
        #     "post_code": "00100",
        # }
        #
        # response = self.client.post("/api/area/create", data)
        #
        # self.assertEqual(response.status_code, 201)
        # self.assertEqual(response.data["data"]["area"], data["area"])
        # self.assertEqual(response.data["data"]["post_code"], data["post_code"])


class TestServicesApi(TestCase):

    def test_create_service(self):
        """
        Tests that a service can be created.
        """
        pass
        # area = AreaCode.objects.create(area="Helsinki", post_code="00100")
        # data = {
        #     "area": area.id,
        #     "name": "Sauna",
        #     "description": "Sauna",
        #     "service_price": 10,
        #     "vat_price": 2,
        # }
        # response = self.client.post("/api/area/services/create", data)
        # self.assertEqual(response.status_code, 201)
        # self.assertEqual(response.data["data"]["area"], data["area"])
        # self.assertEqual(response.data["data"]["name"], data["name"])
        # self.assertEqual(response.data["data"]["description"], data["description"])
        # self.assertEqual(response.data["data"]["service_price"], format(float(data["service_price"]), ".2f"))
        # self.assertEqual(response.data["data"]["vat_price"], format(float(data["vat_price"]), ".2f"))

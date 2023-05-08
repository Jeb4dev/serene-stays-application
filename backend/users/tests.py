import datetime
import time
import jwt
from rest_framework import status
from rest_framework.test import APIClient, APITestCase
from conf.settings import JWT_SECRET
from users.models import User


class TestUser(APITestCase):
    """
    Tests for User model.
    """

    _data = {
        "username": "johndoe",
        "first_name": "John",
        "last_name": "Doe",
        "address": "Texas, USA",
        "phone": "045 123 4567",
        "email": "johndoe@example.com",
        "zip": "12345",
        "password": "SuperSecretPassword",
    }

    # -------------
    # User creation
    # -------------

    def setUp(self) -> dict:
        """
        Setup for User tests.
        """
        self.client = APIClient()
        data = self._data.copy()
        return data

    def create_user(self) -> dict:
        """
        Create a user.
        """
        data = self.setUp()
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        return {
            "email": data["email"],
            "password": data["password"],
        }

    def login_user(self) -> str:
        """
        Login a user and return the jwt token.
        """
        login_data = self.create_user()
        response = self.client.post("/api/user/login", login_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        token = response.data.pop("jwt")
        self.assertTrue(token)
        return token

    def test_user_creation(self):
        """
        Test user creation.
        """
        data = self.setUp()
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_user_without_data(self):
        """
        Test user creation without data.
        """
        response = self.client.post("/api/user/register")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_minimal_user(self):
        """
        Test user creation with minimal data.
        """
        data = {
            "username": "johndoe",
            "email": "jdoe@example.com",
            "password": "SuperSecretPassword",
        }
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_user_with_existing_email(self):
        """
        Test user creation with existing email.
        """
        data = self.setUp()
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data["username"] = "janedoe"
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_user_with_existing_username(self):
        """
        Test user creation with existing username.
        """
        data = self.setUp()
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data["email"] = "janedoe@example.com"
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_user_with_invalid_email(self):
        """
        Test user creation with invalid email.
        """
        data = self.setUp()
        data["email"] = "janedoe"
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_user_with_invalid_username(self):
        """
        Test user creation with invalid username.
        """
        data = self.setUp()
        data["username"] = ""
        response = self.client.post("/api/user/register", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_10_users(self):
        """
        Test user creation with 10 users.
        """
        data = self.setUp()
        for i in range(10):
            data["email"] = f"email-{i}@example.com"
            data["username"] = f"username-{i}"
            response = self.client.post("/api/user/register", data)
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    # -------------
    # User login
    # -------------

    def test_user_login(self):
        """
        Test user login.
        """
        login_data = self.create_user()
        response = self.client.post("/api/user/login", login_data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        token = response.data.pop("jwt")
        self.assertTrue(token)

    def test_user_login_without_data(self):
        """
        Test user login without data.
        """
        response = self.client.post("/api/user/login")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_login_with_invalid_password(self):
        """
        Test user login with invalid data.
        """
        login_data = self.create_user()
        login_data["password"] = "invalid"
        response = self.client.post("/api/user/login", login_data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data, {"result": "error", "message": "Incorrect password!"})

    def test_user_login_with_invalid_email(self):
        """
        Test user login with invalid data.
        """
        login_data = self.create_user()
        login_data["email"] = "invalid@example.com"
        response = self.client.post("/api/user/login", login_data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data, {"result": "error", "message": "User not found!"})

    # -------------
    # User logout
    # -------------

    def test_user_logout(self):
        """
        Test user logout.
        """
        token = self.login_user()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        response = self.client.post("/api/user/logout")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {"result": "success", "message": "Successfully logged out!"})

    # -------------
    # User profile
    # -------------

    def test_user_information(self):
        """
        Test get user information.
        """
        token = self.login_user()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        response = self.client.get("/api/user/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = self._data.copy()
        data.pop("password")
        self.assertEqual(response.data, {"result": "success", "data": data})

    def test_user_information_without_token(self):
        """
        Test get user information without token.
        """
        response = self.client.get("/api/user/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data, {"result": "error", "message": "Unauthenticated!"})

    def test_user_information_with_invalid_token(self):
        """
        Test get user information with invalid token.
        """
        self.client.credentials(
            HTTP_AUTHORIZATION="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTIzNDU2Nzg5LCJuYW1lIjoiSm9zZXBoIn0"
            ".OpOSSw7e485LOP5PrzScxHb7SR6sAOMRckfFwi4rp7o"
        )
        response = self.client.get("/api/user/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data, {"result": "error", "message": "Unauthenticated!"})

    def test_user_information_with_expired_token(self):
        """
        Test get user information with expired token.
        """
        login_data = self.create_user()
        payload = {
            "id": 1,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(seconds=1),
            "iat": datetime.datetime.utcnow(),
        }
        token = jwt.encode(payload, JWT_SECRET, algorithm="HS256")
        self.client.credentials(HTTP_AUTHORIZATION=token)

        response = self.client.get("/api/user/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        time.sleep(2)
        response = self.client.get("/api/user/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_user_information_with_invalid_token_format(self):
        """
        Test get user information with invalid token format.
        """
        self.client.credentials(HTTP_AUTHORIZATION="Bearer")
        response = self.client.get("/api/user/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data, {"result": "error", "message": "Unauthenticated!"})

    # -------------
    # User update
    # -------------

    def test_user_update(self):
        """
        Test user update.
        """
        token = self.login_user()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        data = {
            "username": "new_username",
            "first_name": "James",
            "last_name": "Bond",
            "address": "123 Main St, New York, NY",
            "phone": "1234567890",
            "email": "newemail@example.com",
            "zip": "10030",
        }
        response = self.client.put("/api/user/update", data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {"result": "success", "data": data})

    def test_user_update_without_token(self):
        """
        Test user update without token.
        """
        data = {
            "username": "new_username",
            "first_name": "James",
            "last_name": "Bond",
            "address": "123 Main St, New York, NY",
            "phone": "1234567890",
            "email": "user@example.com",
            "zip": "10030",
        }
        response = self.client.put("/api/user/update", data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data, {"result": "error", "message": "Unauthenticated!"})

    # -------------
    # User delete
    # -------------

    def test_user_delete(self):
        """
        Test user delete.
        """
        token = self.login_user()

        # Change user to admin
        user = User.objects.get(username=self._data["username"])
        user.is_staff = True
        user.save()

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        response = self.client.delete(f"/api/user/delete?user={user.username}")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data, {"result": "success", "message": "User successfully deleted!"})

    def test_user_delete_without_admin(self):
        """
        Test user delete.
        """
        token = self.login_user()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")
        response = self.client.delete(f"/api/user/delete?user={self._data['username']}")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


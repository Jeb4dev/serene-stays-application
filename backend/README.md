# Backend

Django REST API is used as project backend.
It handles all the requests from the frontend and communicates with the database and external APIs like oauth2.

## Setup

### Requirements

- Python 3.9

### Installation

1. Create a virtual environment and activate it
2. Install the requirements with `pip install -r requirements.txt`
3. Run the migrations with `python manage.py migrate`
4. Run the server with `python manage.py runserver`

## API

### Endpoints

- `/api/user/login/` - Login user with username and password
- `/api/user/register/` - Register user with username, email and password and optional other fields
- `/api/user/` - Get user details with token
- `/api/user/update/` - Update user details with optional fields and token

## Tests

To run the tests, run `python manage.py test`.


## License

This project is licensed under the ??? License - see the [LICENSE](/LICENSE) file for details.

## Resources

- [Django REST Framework](https://www.django-rest-framework.org/)
- [Django](https://www.djangoproject.com/)
- [Django OAuth Toolkit](https://django-oauth-toolkit.readthedocs.io/en/latest/)

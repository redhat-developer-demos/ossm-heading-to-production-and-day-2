from locust import HttpUser, task

class TravelAgencyUser(HttpUser):

    def on_start(self):
      """ on_start is called when a Locust start before any task is scheduled """
      self.client.verify = False
      self.client.headers = {'Authorization': 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJqZ25HWTFXZ3JDZTFQd3JnMFltUVRrU05xUF9PMlNCeFVOSW1jX0l5ZzU0In0.eyJleHAiOjE2NjYxODE5MjcsImlhdCI6MTY2NjE4MTYyNywianRpIjoiYTUxOTFkNjEtOTE2NC00ODY4LWI5OWQtNTNhZWZkYzhmNjFmIiwiaXNzIjoiaHR0cHM6Ly9rZXljbG9hay1yaHNzby5hcHBzLm9jcDQucmhsYWIuZGUvYXV0aC9yZWFsbXMvc2VydmljZW1lc2gtbGFiIiwic3ViIjoiNGI1NzI5NzQtZWQ2YS00YmUzLWE3YmQtYzBmMTkwMzNjZmVhIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiaXN0aW8iLCJzZXNzaW9uX3N0YXRlIjoiNGUzN2JkOTUtZDA0ZC00YzRjLWJiMGQtZjFkZjVlZjg5YzI2Iiwic2NvcGUiOiIiLCJzaWQiOiI0ZTM3YmQ5NS1kMDRkLTRjNGMtYmIwZC1mMWRmNWVmODljMjYifQ.SAWMtQlW0SeSIaaChwNGZ0j2zvYRiUdhMNrQ6b4BGQPT6y7fbuF-bUrZTZ-yUkg0gzUaO-qMchguT4XJeZBDmAV5EulCh3fo_iQg0INgIJVaZzj8Aywp8Jat9n6yYswLykJ8GMd47EL7b1kAd1PEG7d4sQUuZUFNtwp4zqFK7wYDI3VpDq7G8G_rYrPGzMlDj7SA6OniRTfUn1kIySOSNbEiqZIDZ9fjXUfgh3wulqb0nWJFpECjAEpm9DzEZNZXkHgOZz_AxYJmjvK22sN7JR0AlUQJVBtJytR21J3f5it0kCTnmVlwI4oSPzzcZ-O5X47RzLkL6Zg1fC-kchvZbw'}

    @task
    def travel_agency(self):
        self.client.get("/flights/Tallinn")
#        self.client.get("/insurances/Athens")


from locust import HttpUser, task

class MyUser(HttpUser):
    @task
    def status(self):
        self.client.get("/status")
    


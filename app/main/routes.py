from . import main


@main.route('/')
def hello_world():
    return 'This is a main page content'

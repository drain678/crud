from flask import Flask
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import request
from psycopg2.sql import SQL, Literal
from dotenv import load_dotenv
import os

load_dotenv()


app = Flask(__name__)
app.json.ensure_ascii = False

connection = psycopg2.connect(
    host=os.getenv('POSTGRES_HOST') if os.getenv('DEBUG_MODE') == 'false' else 'localhost',
    port=os.getenv('POSTGRES_PORT'),
    database=os.getenv('POSTGRES_DB'),
    user=os.getenv('POSTGRES_USER'),
    password=os.getenv('POSTGRES_PASSWORD'),
    cursor_factory=RealDictCursor
)
connection.autocommit = True


# @app.get("/")
# def hello_world():
#     return "<p>Hello, World!</p>"


@app.get("/banks")
def get_banks():
    query = """
    select b.id, b.title, b.founded_in, 
            coalesce(jsonb_agg(jsonb_build_object(
               'id', c.id, 'first_name', c.first_name, 'last_name', c.last_name, 'phone', c.phone))
               filter (where c.id is not null), '[]') as client, 
            coalesce(jsonb_agg(jsonb_build_object(
               'id', t.id, 'amount', t.amount, 'date_of_transaction', t.date_of_transaction, 'description_of_transaction', t.description_of_transaction, 'sender_id', t.sender_id, 'receiver_id', t.receiver_id))
               filter (where t.id is not null), '[]') as transaction
    from banks_data.bank b
    left join banks_data.bank_to_client bc on b.id = bc.bank_id
    left join banks_data.client c on bc.client_id = c.id
    left join banks_data.transaction t on t.sender_id = c.id
    left join banks_data.transaction tr on tr.receiver_id = c.id
    group by b.id
    """

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result


@app.post('/banks/create')
def create_bank():
    body = request.json

    title = body['title']
    founded_in = body['founded_in']

    query = SQL("""
    insert into banks_data.bank(title, founded_in)
    values ({title}, {founded_in})
    returning id
    """).format(title=Literal(title), founded_in=Literal(founded_in))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchone()

    return result


@app.put('/banks/update')
def update_bank():
    body = request.json

    id = body['id']
    title = body['title']
    founded_in = body['founded_in']

    query = SQL("""
    update banks_data.bank
    set 
        title = {title}, 
        founded_in = {founded_in}
    where id = {id}
    returning id
    """).format(title=Literal(title), founded_in=Literal(founded_in), id=Literal(id))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', 404

    return '', 204


@app.delete('/banks/delete')
def delete_bank():
    body = request.json

    id = body['id']

    delete_bank_links = SQL("delete from banks_data.bank_to_client where bank_id = {id}").format(
        id=Literal(id))
    delete_bank = SQL("delete from banks_data.bank where id = {id} returning id").format(
        id=Literal(id))

    with connection.cursor() as cursor:
        cursor.execute(delete_bank_links)
        cursor.execute(delete_bank)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', 404

    return '', 204


@app.get('/banks/find_by_title')
def get_film_by_title():
    title = request.args.get('title')

    query = SQL("""
select id, title, founded_in
from banks_data.bank
where title ilike {title}
""").format(title=Literal('%' + title + '%'))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result


@app.get('/banks/find_by_founded_in')
def get_film_by_year():
    founded_in = request.args.get('founded_in')

    query = SQL("""
select id, title, founded_in
from banks_data.bank
where founded_in = {founded_in}
""").format(founded_in=Literal(founded_in))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result



if __name__ == '__main__':
    app.run(port=os.getenv('FLASK_PORT'))
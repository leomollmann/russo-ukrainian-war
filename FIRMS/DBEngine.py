from time import sleep
import psycopg2

class DBEngine:
  _connection = None
  _retry = 0

  def __init__(self):
    self.connect()

  def connect(self):
    self._connection = psycopg2.connect(
      dbname='warmap',
      user='postgres',
      password='P0@tek_01',
      host='localhost',
      port=5432
    )
    self._retry += 1

  def execute(self, query):
    data = None
    cursor = self._connection.cursor()
    try:
      data = query(cursor)

    except Exception as error:
      if(self._connection.closed > 0):

        if(self._retry > 1):
          sleep(60)

        self.connect()
        self.execute(query)

      else:
        self.rollback()
        raise error

    finally:
      self._retry = 0
      cursor.close()

    return data

  def commit(self):
    self._connection.commit()

  def rollback(self):
    self._connection.rollback()

db_engine = DBEngine()
import pandas as pd
import streamlit as st
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


@st.cache_resource  # build the engine ONCE and reuse it on every rerun
def get_engine():
    c = st.secrets["db"]
    url = URL.create(
        drivername="postgresql+psycopg2",
        username=c["user"],
        password=c["password"],  # special characters like @ are escaped safely
        host=c["host"],
        port=int(c["port"]),
        database=c["name"],
    )
    return create_engine(url, pool_pre_ping=True)


def fetch_all(sql, params=None):
    """Run a SELECT and return a list of dicts (same contract as the Django version)."""
    with get_engine().connect() as conn:
        result = conn.execute(text(sql), params or {})
        return [dict(row._mapping) for row in result]


def fetch_df(sql, params=None):
    """Run a SELECT and return a pandas DataFrame (handy for st.dataframe and charts)."""
    with get_engine().connect() as conn:
        return pd.read_sql(text(sql), conn, params=params or {})


def execute(sql, params=None):
    """Run an INSERT/UPDATE/DELETE inside a transaction (commits automatically)."""
    with get_engine().begin() as conn:
        conn.execute(text(sql), params or {})
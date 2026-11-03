import streamlit as st
from utils.auth import guard, current_user, allowed_pages

guard("home")
user = current_user()

st.title(f"Welcome, {user['full_name']} 👋")
st.write(f"You are signed in as **{user['role_name']}**.")

st.subheader("What this role can open")
st.write(" · ".join(p.replace("_", " ").title() for p in allowed_pages(user["role_name"])))
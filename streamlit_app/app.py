import streamlit as st
from utils.auth import current_user, demo_login_screen, logout, allowed_pages

# Must be the FIRST Streamlit call in the entry file.
st.set_page_config(page_title="ALSJ Travel Agency", page_icon="✈️", layout="wide")

# key -> page object (files live in views/, NOT pages/)
PAGES = {
    "home":           st.Page("views/home.py", title="Home", icon="🏠", default=True),
    "applications":   st.Page("views/applications.py", title="Applications", icon="📋"),
    "documents":      st.Page("views/documents.py", title="Documents", icon="📄"),
    "payments":       st.Page("views/payments.py", title="Payments", icon="💳"),
    "appointments":   st.Page("views/appointments.py", title="Appointments", icon="📅"),
    "notifications":  st.Page("views/notifications.py", title="Notifications", icon="🔔"),
    "analytics":      st.Page("views/analytics.py", title="Analytics", icon="📊"),
    "table_viewer":   st.Page("views/table_viewer.py", title="Table Viewer", icon="🗂️"),
    "data_dictionary": st.Page("views/data_dictionary.py", title="Data Dictionary", icon="📖"),
    "erd":            st.Page("views/erd.py", title="ERD Diagram", icon="🗺️"),
    "audit":          st.Page("views/audit.py", title="Audit Log", icon="🛡️"),
    "system_flow":    st.Page("views/system_flow.py", title="System Flow", icon="🧭"),
}

# sidebar sections (just grouping for looks)
SECTIONS = {
    "Overview": ["home"],
    "Operations": ["applications", "documents", "payments", "appointments", "notifications"],
    "Insights": ["analytics", "system_flow"],
    "Data & Admin": ["table_viewer", "data_dictionary", "erd", "audit"],
}

user = current_user()
if not user:
    demo_login_screen()
    st.stop()

# Build a menu containing ONLY what this role may see
allowed = set(allowed_pages(user["role_name"]))
menu = {
    section: [PAGES[k] for k in keys if k in allowed]
    for section, keys in SECTIONS.items()
}
menu = {section: pages for section, pages in menu.items() if pages}

nav = st.navigation(menu)

with st.sidebar:
    st.divider()
    st.markdown(f"**{user['full_name']}**")
    st.caption(f"Role: {user['role_name']}")
    st.button("🔄 Switch role", on_click=logout, use_container_width=True)

nav.run()
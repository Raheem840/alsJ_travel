import streamlit as st
from utils.db import fetch_all

# ---------------------------------------------------------------
# 1. THE RBAC TABLE: which pages each role may open.
#    Keys must match roles.role_name (upper-cased, spaces -> _).
#    Page keys must match the keys in app.py.
# ---------------------------------------------------------------
import bcrypt  
ROLE_ACCESS = {
    "DIRECTOR": ["home", "applications", "documents", "payments", "appointments",
                 "notifications", "analytics", "system_flow", "table_viewer",
                 "data_dictionary", "erd", "audit"],
    "SECRETARY": ["home", "applications", "documents", "payments", "appointments",
                  "notifications", "system_flow", "table_viewer"],
    "AGENT": ["home", "applications", "documents", "appointments",
              "notifications", "system_flow"],
    "CLIENT": ["home", "applications", "documents", "payments",
               "appointments", "notifications", "system_flow"],
}

# What each role may DO in the Table Viewer (separate from what it may SEE)
CRUD_RIGHTS = {
    "DIRECTOR": {"create", "update", "delete"},
    "SECRETARY": {"create", "update"},          # no deleting
}
READ_ONLY_TABLES = {"audit_logs", "stage_history"}   # history must be immutable
HIDDEN_TABLES = {"SECRETARY": {"audit_logs", "users"}}  # tables a role can't even list


def can(role_name, action):
    return action in CRUD_RIGHTS.get(normalize_role(role_name), set())


def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def normalize_role(role_name):
    return (role_name or "").strip().upper().replace(" ", "_")


def allowed_pages(role_name):
    """Pages a role may open. Unknown roles only get the home page."""
    return ROLE_ACCESS.get(normalize_role(role_name), ["home"])


# ---------------------------------------------------------------
# 2. SESSION STATE: remembers who is "logged in" between reruns.
# ---------------------------------------------------------------
def current_user():
    return st.session_state.get("user")


def login_as(user):
    st.session_state["user"] = {
        "user_id": str(user["user_id"]),
        "full_name": user["full_name"],
        "role_name": user["role_name"],
    }


def logout():
    st.session_state.pop("user", None)


# ---------------------------------------------------------------
# 3. THE GUARD: every page calls this first. Hiding a menu link is
#    cosmetics; the guard is the actual enforcement.
# ---------------------------------------------------------------
def guard(page_key):
    user = current_user()
    if not user:
        st.warning("Please choose a role on the home screen first.")
        st.stop()
    if page_key not in allowed_pages(user["role_name"]):
        st.error(f"🚫 The {user['role_name']} role cannot open this page.")
        st.stop()


# ---------------------------------------------------------------
# 4. DEMO LOGIN SCREEN: pick a role, pick a person, enter. No password.
# ---------------------------------------------------------------
@st.cache_data(ttl=60)
def _demo_users():
    return fetch_all(
        """SELECT u.user_id, u.full_name, u.phone, r.role_id, r.role_name
           FROM users u JOIN roles r ON r.role_id = u.role_id
           WHERE u.is_active
           ORDER BY r.role_id, u.full_name"""
    )


def demo_login_screen():
    st.markdown("# ✈️ ALSJ Travel Agency")
    st.caption("Demo mode: choose a role to see the portal as that person.")

    users = _demo_users()
    if not users:
        st.error("No active users found in the database.")
        st.stop()

    roles = list(dict.fromkeys(u["role_name"] for u in users))  # unique, keeps order
    left, right = st.columns(2)
    role = left.selectbox("Role", roles)
    people = [u for u in users if u["role_name"] == role]
    person = right.selectbox("Person", people, format_func=lambda u: u["full_name"])

    if normalize_role(role) not in ROLE_ACCESS:
        st.warning(
            f"Role '{role}' is not in ROLE_ACCESS yet, so it will only see Home. "
            f"Add the key '{normalize_role(role)}' in utils/auth.py."
        )

    if st.button(f"Enter as {person['full_name']}", type="primary"):
        login_as(person)
        st.rerun()
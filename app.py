from flask import Flask, render_template, request, redirect, url_for, flash, session,g
import sqlite3
import os
from datetime import datetime, timedelta
import random
from werkzeug.security import generate_password_hash, check_password_hash

project_root = os.path.dirname(os.path.abspath(__file__))#Ndumiso add
DATABASE = os.path.join(project_root, 'inventory.db')


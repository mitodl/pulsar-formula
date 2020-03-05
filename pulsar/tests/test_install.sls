{% from "pulsar/map.jinja" import pulsar with context %}

{% for pkg in pulsar.pkgs %}
test_{{pkg}}_is_installed_for_pulsar:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}

test_pulsar_archive_installed:
  testinfra.file:
    - name: /opt/pulsar
    - exists: True
    - is_symlink: True
    - linked_to:
        expected: /opt/apache-pulsar-{{ pulsar.version }}
        comparison: eq
    - user:
        expected: {{ pulsar.user }}
        comparison: eq
    - group:
        expected: {{ pulsar.group }}
        comparison: eq

{% for service_name in pulsar.services %}
test_pulsar_service_{{ service_name }}_running:
  testinfra.service:
    - name: pulsar-{{ service_name }}
    - is_running: True
    - is_enabled: True
{% endfor %}

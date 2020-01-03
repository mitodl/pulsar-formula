{% from "pulsar/map.jinja" import pulsar with context %}

{% for pkg in pulsar.pkgs %}
test_{{pkg}}_is_installed:
  testinfra.package:
    - name: {{ pkg }}
    - is_installed: True
{% endfor %}

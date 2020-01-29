{% from "pulsar/map.jinja" import pulsar with context %}

{% for service_name in pulsar.services %}
pulsar_{{ service_name }}_service_running:
  service.running:
    - name: pulsar-{{ service_name }}
    - enable: True
{% endfor %}

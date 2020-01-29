{% from "pulsar/map.jinja" import pulsar, pulsar_configs, file_types with context %}

include:
  - .service

{% for config_file, settings in pulsar.config.items() %}
{% set file_extension = config_file.rsplit('.')[-1] %}
{% set file_type = file_types[file_extension] %}
{% set service_name = pulsar_configs.get(config_file, {}).get('service', 'broker') %}
configure_pulsar_{{ config_file }}:
  file.managed:
    - name: /opt/apache-pulsar-{{ pulsar.version }}/conf/{{ config_file }}
    - source: salt://pulsar/templates/{{ file_type }}.jinja
    - template: jinja
    - context:
        settings: {{ settings|tojson }}
    {% if service_name in pulsar.services %}
    - watch_in:
      - service: pulsar_{{ service_name }}_service_running
    - require_in:
      - service: pulsar_{{ service_name }}_service_running
    {% endif %}
    - backup: minion
{% endfor %}

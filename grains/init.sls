{% set system_grains = salt['pillar.get']('grains:systems', {}) %}
{% set custom_grains = system_grains.get(grains.get('id'), salt['pillar.get']('grains:categories:default', {})) %}
{% set all_category_grains = salt['pillar.get']('grains:categories', {}) %}
{% set categories = [] %}
{% macro parsecategories(local_categories) %}
  {% for category in local_categories %}
    {% if category not in categories %}
      {% do categories.extend([category]) %}
    {% endif %}
    {% set category_grains = all_category_grains.get(category, {}) %}
    {% set more_categories = category_grains.get('categories', []) %}
    {{ parsecategories(more_categories) }}
  {% endfor %}
{% endmacro %}

{% do parsecategories(custom_grains.get('categories', ['default'])) %}

{% if custom_grains == salt['pillar.get']('grains:categories:default', {}) %}
  {% do categories.extend(['default']) %}
{% endif %}

{% do custom_grains.update({'categories': categories}) %}
{% for category in categories %}
  {% set category_grains = all_category_grains.get(category, {}) %}
  {% for index in ['roles', 'sudoers.included'] %}
    {% if index not in category_grains.keys() %}
      {% do category_grains.update({index: []}) %}
    {% endif %}
    {% if index not in custom_grains.keys() %}
      {% do custom_grains.update({index: []}) %}
    {% endif %}
    {% set items = category_grains.get(index, []) %}
    {% for item in category_grains[index] %}
      {% if item not in custom_grains[index] %}
        {% do custom_grains[index].extend([item]) %}
      {% endif %} 
    {% endfor %}
  {% endfor %}
{% endfor %}

/etc/salt/grains:
  file.managed:
    - source: 
      - salt://grains/files/grains
    - user: root
    - group: root
    - mode: '0644'
    - template: py
    - context: 
        custom_grains: {{ custom_grains }}


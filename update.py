import yaml
from jinja2 import Template


def load_config(file):
    """
    Load image configuration from yaml file
    """   
    with open(file) as config:
        image_config = yaml.load(config.read())
    return image_config


def load_template(file):
    """
    Loads Jinja template for dockerfile
    """
    with open(file) as template:
        dockerfile_template = template.read()
    return dockerfile_template


def render_template(template, data):
    """
    Render dockerfile with Jinja template and configuration data
    """
    dockerfile_template = Template(template)
    return dockerfile_template.render(**data)


def generate_dockerfile(config_file='image.yml', template_file='Dockerfile.template'):
    """
    Generate the Dockerfile
    """
    config = load_config(config_file)
    template = load_template(template_file)
    dockerfile = render_template(template, config)

    print(f'Rendered Dockerfile with following configuration:',
          *[f"\t{k.replace('_', ' ').title():<22}: {v}" 
            for k, v in config.items()],
          sep='\n')
    print('Saving Dockerfile... ', end='')
    with open('Dockerfile', 'w') as file:
        file.write(dockerfile)
    print('Done')


if __name__ == '__main__':
    generate_dockerfile()

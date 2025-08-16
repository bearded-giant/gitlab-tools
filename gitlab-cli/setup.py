# Copyright 2024 BeardedGiant
# https://github.com/bearded-giant/gitlab-tools
# Licensed under Apache License 2.0

from setuptools import setup, find_packages
from pathlib import Path

this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text()

setup(
    name="gitlab-cli-explorer",
    version="0.1.0",
    author="BeardedGiant",
    description="CLI tool for exploring GitLab pipelines and job statuses",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/bearded-giant/gitlab-tools",
    license="Apache-2.0",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Version Control :: Git",
    ],
    python_requires=">=3.8",
    install_requires=[
        "python-gitlab>=3.0.0",
    ],
    entry_points={
        "console_scripts": [
            "gitlab-cli=gitlab_cli.cli:main",
            "gl=gitlab_cli.cli:main",  # Short alias
        ],
    },
    include_package_data=True,
)
import argparse
from pathlib import Path

from rdflib import Graph

def main():
    parser = argparse.ArgumentParser(description="Convert from RDF-XML to Turtle")
    parser.add_argument("input_file", type=Path, help="Input file (RDF-XML format)")
    args = parser.parse_args()
    output_file = args.input_file.stem + ".ttl"

    g = Graph()
    g.parse(str(args.input_file), format="xml")
    g.serialize(destination=str(output_file), format="turtle")

if __name__ == "__main__":
    main()
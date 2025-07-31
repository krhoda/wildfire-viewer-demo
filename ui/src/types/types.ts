export type GeometrySection = {
  coordinates: [number, number];
  type: "Point";
};

export type PropertiesSection = {
  name: string;
};

export type Incoming = {
  geometry: GeometrySection;
  properties: PropertiesSection;
  type: "Feature";
};

export type Perims = {
  type: "Feature";
  properties: {
    name: string;
  };
  geometry: {
    type: "Polygon";
    coordinates: Array<[number, number]>;
  };
};

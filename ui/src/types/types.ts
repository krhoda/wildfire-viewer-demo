export type GeometrySection = {
  coordinates: [number, number]
  type: "Point",
}

export type PropertiesSection = {
  name: string,
}

export type Incoming = {
  geometry: GeometrySection,
  properties: PropertiesSection,
  type: "Feature",
}
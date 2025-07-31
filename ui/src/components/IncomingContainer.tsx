import type { Incoming } from '../types/types'

export function IncomingContianer(incoming: Incoming) {
    return (<>
        <p>Name: {incoming.properties.name}</p>
        <p>X: {incoming.geometry.coordinates[0]}, Y: {incoming.geometry.coordinates[1]}</p>
    </>)
}
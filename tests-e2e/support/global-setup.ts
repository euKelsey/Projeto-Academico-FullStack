import { verificarAmbienteIsolado } from './ambiente';

export default async function globalSetup(): Promise<void> {

    console.log(
        '=== VERIFICANDO ISOLAMENTO DO AMBIENTE E2E ==='
    );

    await verificarAmbienteIsolado();

    console.log(
        '=== AMBIENTE E2E AUTORIZADO ==='
    );

}

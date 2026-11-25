import {
    test as base,
    expect,
} from '@playwright/test';

import {
    restaurarBancoTeste,
} from './banco';

type FixturesFastSplash = {

    bancoRestaurado: void;

};

export const test = base.extend<FixturesFastSplash>({

    bancoRestaurado: [

        async ({}, use) => {

            restaurarBancoTeste();

            try {

                await use();

            } finally {

                restaurarBancoTeste();

            }

        },

        {
            auto: true,
        },

    ],

});

export { expect };

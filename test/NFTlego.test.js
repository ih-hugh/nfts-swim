import chai from 'chai';
import spies from 'chai-spies';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { NFTLego } from '../src';

chai.use(spies);

const { assert, expect } = chai;

describe('NFTLego', function () {
  let contractId = '0xca791bda96927bd48d1f5afad52e1ac4996c65c2';
  let tokenId = '12';
  let order = {
    hash: 23465235634563456,
    data: {
      payouts: [],
      originFees: [],
    },
  };

  const getSellOrderURL = `https://api-staging.rarible.com/protocol/v0.1/ethereum/order/orders/sell/byItem?contract=${contractId}&tokenId=${tokenId}`;
  const prepareTXURL = `https://api-staging.rarible.com/protocol/v0.1/ethereum/order/orders/${order.hash}/prepareTx`;
  let nftLego = null;

  beforeEach(function () {
    nftLego = new NFTLego();
  });

  it('should construct without errors', function () {
    assert(nftLego, true);
  });

  it('should call getSellOrdersByItem method and return response data', async function () {
    const spy = chai.spy(nftLego.getSellOrdersByItem);
    spy({ contractId, tokenId });
    expect(spy).to.have.been.called.with({ contractId, tokenId });

    let mock = new MockAdapter(axios);
    mock.onGet(getSellOrderURL).reply(function () {
      return [200, 'success'];
    });

    try {
      const response = await nftLego.getSellOrdersByItem({
        contractId,
        tokenId,
      });

      expect(response.data).to.equal('success');
    } catch (error) {
      console.error(error.message);
    }
  });

  it('should call createPool', function () {
    const createPoolSpy = chai.spy(nftLego.createPool);
    // const getSellOrdersByItemSpy = chai.spy(nftLego.getSellOrdersByItem);
    // const getPreparedOrdersFromSpy = chai.spy(nftLego.getPreparedOrdersFrom);
    // const prepareTXSpy = chai.spy(nftLego.prepareTX);

    createPoolSpy({ contractId, tokenId });
    expect(createPoolSpy).to.have.been.called();
  });

  it('should call getPreparedOrdersFrom and return prepared ordered', async function () {
    const spy = chai.spy(nftLego.getPreparedOrderFrom);
    await spy(order);
    expect(spy).to.have.been.called.with(order);
  });

  it('should call prepareTX and return response', async function () {
    const spy = chai.spy(nftLego.prepareTX);
    console.log('DATA: ', order);
    await spy(order);
    expect(spy).to.have.been.called.with(order);

    let mock = new MockAdapter(axios);
    mock.onGet(prepareTXURL).reply(function () {
      return [200, 'success'];
    });

    try {
      const response = await nftLego.prepareTX({
        order,
      });

      expect(response.data).to.equal('success');
    } catch (error) {
      console.error(error.message);
    }
  });
});

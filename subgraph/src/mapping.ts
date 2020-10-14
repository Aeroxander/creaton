/* eslint-disable prefer-const */
import {CreatorDeployedEvent} from '../generated/Creaton/CreatonContract';
import {CreatorDeployed} from '../generated/schema';
// import {log} from '@graphprotocol/graph-ts';

// const zeroAddress = '0x0000000000000000000000000000000000000000';

export function handleMessageChanged(event: CreatorDeployedEvent): void {
  let id = event.params.user.toHex();
  let entity = CreatorDeployed.load(id);
  if (!entity) {
    entity = new CreatorDeployed(id);
  }
  entity.user = event.params.user;
  entity.creatorContract = event.params.creatorContract;
  entity.timestamp = event.block.timestamp;
  entity.save();
}

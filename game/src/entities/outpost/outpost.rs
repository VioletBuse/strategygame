use crate::entities::outpost::location::OutpostLocation;
use crate::entities::outpost::owner::OutpostOwner;
use crate::entities::outpost::variant::OutpostVariant;
use typed_builder::TypedBuilder;

#[derive(Clone, Debug, TypedBuilder)]
pub struct Outpost {
    #[builder(setter(into))]
    id: i64,
    #[builder(setter(into))]
    variant: OutpostVariant,
    #[builder(setter(into))]
    owner: OutpostOwner,
    #[builder(setter(into))]
    location: OutpostLocation,
}

#[cfg(test)]
mod test {
    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn outpost_builder() {
        let outpost = Outpost::builder()
            .id(23)
            .owner(None)
            .location((5.0, 6.0))
            .variant("mine".to_string())
            .build();

        assert_eq!(outpost.id, 23);
        assert_eq!(outpost.variant.is_factory(), false);
        assert_eq!(outpost.owner.is_owned_outpost(), false);
        assert_eq!(outpost.location.is_known_outpost_location(), true);
    }
}

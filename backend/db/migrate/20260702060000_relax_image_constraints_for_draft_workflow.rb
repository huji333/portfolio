class RelaxImageConstraintsForDraftWorkflow < ActiveRecord::Migration[8.1]
  # Bulk ingest creates title-less/caption-less drafts, so publish-quality
  # requirements move to the model layer (validated only when is_published).
  # Publishing becomes an explicit act: the DB default flips to draft.
  def change
    change_column_null :images, :title, true
    change_column_null :images, :caption, true
    change_column_null :images, :taken_at, true
    change_column_default :images, :is_published, from: true, to: false
  end
end
